#include <assert.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>

#include "cassandra.h"

#define NUM_CONCURRENT_REQUESTS 10000

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

typedef struct _pfile {
  char **fnames;
  int num_files;
  const CassPrepared *prepared;
  CassSession *session;
  int myid;
  int num_threads;
  int retval;
} pfile;

void* process_files(void* args) {
  CassFuture *futures[NUM_CONCURRENT_REQUESTS];
  CassFuture *future;
  CassStatement *statement = NULL;
  CassError rc = CASS_OK;
  long long lineNumber = 0;
  char *pkey, *ccolstr, *data;
  char *endptr;
  long long ccol;
  int i, fidx;
  FILE *fp;

  char **fnames = ((pfile*)args)->fnames;
  int num_files = ((pfile*)args)->num_files;
  const CassPrepared *prepared = ((pfile*)args)->prepared;
  CassSession *session = ((pfile*)args)->session;
  int myid = ((pfile*)args)->myid;
  int num_threads = ((pfile*)args)->num_threads;
  time_t t;

  char *buf = NULL;
  buf = (char*)malloc(1048576000+100);
  if (NULL == buf) {
    fprintf(stderr, "Thread %d: Couldn't malloc buffer\n", myid);
    exit(1);
  }

  for (int fidx = 0; fidx < num_files; fidx++) {
    if (myid != fidx % num_threads)
      continue;

    fp = NULL;
    fp = fopen(fnames[fidx], "rb");
    if (NULL == fp) {
      fprintf(stderr, "Thread %d: Could not open input file (%s).... skipping\n", myid, fnames[fidx]);
      continue;
    }
    fprintf(stderr, "\nThread %d: Processing file %s\n", myid, fnames[fidx]);
    time(&t);
    fprintf(stderr, "    %s\n\n", ctime(&t));

    lineNumber = 0;
    while (1 == fscanf(fp, "%[^\n]\n", buf)) {
      pkey = buf;
      buf[12] = '\0';
      ccolstr = &buf[13];
      i = 14;
      while (buf[i] != ',')
	i++;
      buf[i] = '\0';
      data = &buf[i+1];
      ccol = strtoll(ccolstr, &endptr, 10);
      statement = cass_prepared_bind(prepared);
      cass_statement_bind_string(statement, 0, cass_string_init(pkey));
      cass_statement_bind_int64(statement, 1, (cass_int64_t)ccol);
      cass_statement_bind_string(statement, 2, cass_string_init(data));
      futures[lineNumber] = cass_session_execute(session, statement);
      cass_statement_free(statement);
      lineNumber++;
      
      if (NUM_CONCURRENT_REQUESTS == lineNumber) {
	for (i = 0; i < NUM_CONCURRENT_REQUESTS; i++) {
	  future = futures[i];
	  cass_future_wait(future);
	  rc = cass_future_error_code(future);
	  if (rc != CASS_OK)
	    print_error(future);
	  cass_future_free(future);
	}
	lineNumber = 0;
      }

    }
    fclose(fp);
  }

  free(buf);
  ((pfile*)args)->retval = 0;
  return &(((pfile*)args)->retval);
}

int main(int argc, char** argv) {
  if (argc < 5) {
    fprintf(stderr, "Usage: %s <num threads> <ip address> <tablename> <filename> [<filename>]\n", argv[0]);
    return 1;
  }
  int num_threads = atoi(argv[1]);
  char *ip = argv[2];
  char *tablename = argv[3];
  char keyspace[] = "test";
  int num_files = argc - 4;
  char *fnames[num_files];
  for (int i = 0; i < num_files; i++)
    fnames[i] = argv[i+4];

  CassCluster *cluster = create_cluster(ip);
  cass_cluster_set_num_threads_io(cluster, 4);
  cass_cluster_set_queue_size_io(cluster, 10000);
  cass_cluster_set_pending_requests_low_water_mark(cluster, 5000);
  cass_cluster_set_pending_requests_high_water_mark(cluster, 10000);
  cass_cluster_set_core_connections_per_host(cluster, 8);
  cass_cluster_set_max_connections_per_host(cluster, 8);
  cass_cluster_set_write_bytes_high_water_mark(cluster, 128 * 1024);
  cass_cluster_set_write_bytes_low_water_mark(cluster, 64 * 1024);
  cass_cluster_set_queue_size_io(cluster, NUM_CONCURRENT_REQUESTS * (num_threads + 1));

  CassSession *session = cass_session_new();
  CassFuture *close_future = NULL;

  if (connect_session(session, cluster) != CASS_OK) {
    cass_cluster_free(cluster);
    cass_session_free(session);
    return -1;
  }

  char cquery[1000];
  sprintf(cquery, "INSERT INTO %s.%s (pkey, ccol, data) VALUES (?, ?, ?);", keyspace, tablename);
  CassString query = cass_string_init(cquery);
  const CassPrepared *prepared;
  if (prepare_insert(session, query, &prepared) != CASS_OK) {
    fprintf(stderr, "Could not prepare query: %s", cquery);
    close_future = cass_session_close(session);
    cass_future_wait(close_future);
    cass_future_free(close_future);
    cass_cluster_free(cluster);
    cass_session_free(session);
    return -1;
  }

  pthread_t tid[num_threads];
  pfile todo[num_threads];
  for (int i = 0; i < num_threads; i++) {
    todo[i].fnames = fnames;
    todo[i].num_files = num_files;
    todo[i].myid = i;
    todo[i].num_threads = num_threads;
    todo[i].prepared = prepared;
    todo[i].session = session;
    todo[i].retval = -1;
    pthread_create(&tid[i], NULL, process_files, &todo[i]);
  }

  for (int i = 0; i < num_threads; i++)
    pthread_join(tid[i], NULL);

  close_future = cass_session_close(session);
  cass_future_wait(close_future);
  cass_future_free(close_future);

  cass_cluster_free(cluster);
  cass_session_free(session);

  return 0;
}
