#include <assert.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "cassandra.h"

#define NUM_CONCURRENT_REQUESTS 20000

void print_error(CassFuture* future) {
  CassString message = cass_future_error_message(future);
  fprintf(stderr, "Error: %.*s\n", (int)message.length, message.data);
}


CassCluster* create_cluster(char *conn) {
  CassCluster* cluster = cass_cluster_new();
  cass_cluster_set_contact_points(cluster, conn);
  return cluster;
}

CassError connect_session(CassSession* session, const CassCluster* cluster) {
  CassError rc = CASS_OK;
  CassFuture* future = cass_session_connect(session, cluster);

  cass_future_wait(future);
  rc = cass_future_error_code(future);
  if (rc != CASS_OK) {
    print_error(future);
  }
  cass_future_free(future);

  return rc;
}

CassError execute_query(CassSession* session, const char* query) {
  CassError rc = CASS_OK;
  CassFuture* future = NULL;
  CassStatement* statement = cass_statement_new(cass_string_init(query), 0);

  future = cass_session_execute(session, statement);
  cass_future_wait(future);

  rc = cass_future_error_code(future);
  if (rc != CASS_OK) {
    print_error(future);
  }

  cass_future_free(future);
  cass_statement_free(statement);

  return rc;
}

CassError prepare_insert(CassSession *session, CassString query, const CassPrepared **prepared) {
  CassError rc = CASS_OK;
  CassFuture *future = NULL;

  future = cass_session_prepare(session, query);
  cass_future_wait(future);
  rc = cass_future_error_code(future);
  if (rc != CASS_OK)
    print_error(future);
  else
    *prepared = cass_future_get_prepared(future);

  cass_future_free(future);
  return rc;
}

int main(int argc, char** argv) {
  if (argc != 4) {
    fprintf(stderr, "Usage: %s <filename> <ip address> <tablename>\n", argv[0]);
    return 1;
  }
  char *filename = argv[1];
  char *ip = argv[2];
  char *tablename = argv[3];
  char keyspace[] = "test";

  FILE *fp = NULL;
  fp = fopen(filename, "rb");
  if (NULL == fp) {
    fprintf(stderr, "Could not open input file (%s)\n", filename);
    return 1;
  }
  char *buf = NULL;
  buf = (char*)malloc(1048576000+100);
  if (NULL == buf) {
    fprintf(stderr, "Couldn't malloc buffer\n");
    fclose(fp);
    return 1;
  }

  CassCluster *cluster = create_cluster(ip);
  cass_cluster_set_num_threads_io(cluster, 4);
  cass_cluster_set_queue_size_io(cluster, 10000);
  cass_cluster_set_pending_requests_low_water_mark(cluster, 5000);
  cass_cluster_set_pending_requests_high_water_mark(cluster, 10000);
  cass_cluster_set_core_connections_per_host(cluster, 8);
  cass_cluster_set_max_connections_per_host(cluster, 8);
  cass_cluster_set_write_bytes_high_water_mark(cluster, 1024 * 1024);
  cass_cluster_set_write_bytes_low_water_mark(cluster, 512 * 1024);

  CassSession *session = cass_session_new();
  CassFuture *close_future = NULL;

  if (connect_session(session, cluster) != CASS_OK) {
    cass_cluster_free(cluster);
    cass_session_free(session);
    fclose(fp);
    free(buf);
    return -1;
  }

  CassError rc = CASS_OK;
  CassStatement *statement = NULL;
  char cquery[1000];
  sprintf(cquery, "INSERT INTO %s.%s (pkey, ccol, data) VALUES (?, ?, ?);", keyspace, tablename);
  CassString query = cass_string_init(cquery);
  const CassPrepared *prepared;
  if (prepare_insert(session, query, &prepared) != CASS_OK) {
    fprintf(stderr, "Could not prepare query: %s", cquery);
    free(buf);
    close_future = cass_session_close(session);
    cass_future_wait(close_future);
    cass_future_free(close_future);
    cass_cluster_free(cluster);
    cass_session_free(session);
    fclose(fp);
    free(buf);
    return -1;
  }

  CassFuture *futures[NUM_CONCURRENT_REQUESTS];
  long long lineNumber = 0;
  while (1 == fscanf(fp, "%[^\n]\n", buf)) {
    char *pkey, *ccolstr, *data;
    pkey = buf;
    buf[12] = '\0';
    ccolstr = &buf[13];
    int i = 14;
    while (buf[i] != ',')
      i++;
    buf[i] = '\0';
    data = &buf[i+1];
    char *endptr;
    long long ccol = strtoll(ccolstr, &endptr, 10);
//    statement = cass_statement_new(query, 3);
    statement = cass_prepared_bind(prepared);
    cass_statement_bind_string(statement, 0, cass_string_init(pkey));
    cass_statement_bind_int64(statement, 1, (cass_int64_t)ccol);
    cass_statement_bind_string(statement, 2, cass_string_init(data));
    futures[lineNumber] = cass_session_execute(session, statement);
    cass_statement_free(statement);
    lineNumber++;

    if (NUM_CONCURRENT_REQUESTS == lineNumber) {
      for (i = 0; i < NUM_CONCURRENT_REQUESTS; i++) {
        CassFuture *future = futures[i];
        cass_future_wait(future);
        rc = cass_future_error_code(future);
        if (rc != CASS_OK)
          print_error(future);
        cass_future_free(future);
      }
      lineNumber = 0;
    }
  }

  free(buf);
  close_future = cass_session_close(session);
  cass_future_wait(close_future);
  cass_future_free(close_future);

  cass_cluster_free(cluster);
  cass_session_free(session);
  fclose(fp);

  return 0;
}
