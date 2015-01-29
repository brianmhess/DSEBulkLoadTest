import java.nio.ByteBuffer;
import java.io.*;
import java.util.*;
import java.lang.*;
import java.net.InetAddress;

import org.apache.cassandra.io.sstable.CQLSSTableWriter;
import org.apache.cassandra.exceptions.InvalidRequestException;
import org.apache.cassandra.config.Config;

import com.datastax.driver.core.Cluster;
import com.datastax.driver.core.Metadata;
import com.datastax.driver.core.Session;
import com.datastax.driver.core.PreparedStatement;
import com.datastax.driver.core.BoundStatement;
import com.datastax.driver.core.Host;

public class TestSSTableWriterSplit10 {
  static String filename;
  String outdir;
  String ip = "127.0.0.1";
  String keyspace = "";
  String table = "";
  String delimiter = ",";
  String schema = "";
  String insert = "";
  String dummyString = "";
  long dummyLong = 0;

  Cluster cluster;
  Session session;
  Metadata metadata;
  PreparedStatement stmt;

  private void init() {
    cluster = Cluster.builder().addContactPoint(ip).build();
    metadata = cluster.getMetadata();
    session = cluster.newSession();
    stmt = session.prepare(insert);
  }

  private void cleanup() {
    session.close();
    cluster.close();
  }

  private boolean contains(long pkey) {
    BoundStatement bind = stmt.bind(pkey, dummyLong, dummyLong, dummyLong, dummyLong, dummyLong, dummyLong, dummyLong, dummyLong, dummyLong);
    ByteBuffer bb = bind.getBytesUnsafe(0);
    Set<Host> endpts = metadata.getReplicas(keyspace, bb);
    for (Host h : endpts)
      if (ip.equalsIgnoreCase(h.getAddress().getHostAddress()))
        return true;
    return false;
  }

  public void run(String[] args) throws IOException {
    if (args.length != 4) {
      System.err.println("Expecting 5 arguments: <filename> <output directory> <keyspace> <IP address>");
      System.exit(1);
    }
    filename = args[0];
    outdir = args[1];
    keyspace = args[2];
    table = "test10";
    ip = args[3];
    Config.setClientMode(true);
    BufferedReader reader = new BufferedReader(new FileReader(filename));
    File directory = new File(keyspace);
    if (!directory.exists())
      directory.mkdir();
    CsvParser parser = new CsvParser();
    schema = "CREATE TABLE " + keyspace + "." + table + " (pkey BIGINT, ccol BIGINT, c1 BIGINT, c2 BIGINT, c3 BIGINT, c4 BIGINT, c5 BIGINT, c6 BIGINT, c7 BIGINT, c8 BIGINT, PRIMARY KEY ((pkey), ccol));";
    insert = "INSERT INTO " + keyspace + "." + table + " (pkey, ccol, c1, c2, c3, c4, c5, c6, c7, c8) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    CQLSSTableWriter writer = CQLSSTableWriter.builder().inDirectory(outdir).forTable(schema).using(insert).build();

    String line;
    int lineNumber = 1;
    long timestamp = System.currentTimeMillis() * 1000;

    init();

    while ((line = reader.readLine()) != null) {
      if (parser.parse(line, delimiter, lineNumber)) {
        if (0 == lineNumber % 10000)
          System.err.println("Got to line " + lineNumber);
        if (contains(parser.pkey))
          parser.addRow(writer);
      }
      lineNumber++;
    }

    cleanup();

    writer.close();
    System.exit(0);
  }

  static class CsvParser {
    public long pkey;
    public long ccol;
    public long c1;
    public long c2;
    public long c3;
    public long c4;
    public long c5;
    public long c6;
    public long c7;
    public long c8;
    static int numCols = 10;
    boolean parse(String line, String delimiter, int lineNumber) {
      String[] columns = line.split(delimiter);
      if (numCols != columns.length) {
        System.err.println(String.format("Invalid input '%s' at line %d of %s", line, lineNumber, filename));
        return false;
      }
      try {
        pkey = Long.parseLong(columns[0].trim());
        ccol = Long.parseLong(columns[1].trim());
        c1   = Long.parseLong(columns[2].trim());
        c2   = Long.parseLong(columns[3].trim());
        c3   = Long.parseLong(columns[4].trim());
        c4   = Long.parseLong(columns[5].trim());
        c5   = Long.parseLong(columns[6].trim());
        c6   = Long.parseLong(columns[7].trim());
        c7   = Long.parseLong(columns[8].trim());
        c8   = Long.parseLong(columns[9].trim());
        return true;
      }
      catch (NumberFormatException e) {
        System.err.println(String.format("Invalid number in input '%s' at line %d of %s", line, lineNumber, filename));
        return false;
      }
    }
    void addRow(CQLSSTableWriter writer) {
      try {
        writer.addRow(pkey, ccol, c1, c2, c3, c4, c5, c6, c7, c8);
      }
      catch (Exception e) {
        System.err.println("Couldn't addRow");
      }
    }
  }

  public static void main(String [] args) throws IOException {
    TestSSTableWriterSplit10 n = new TestSSTableWriterSplit10();
    n.run(args);
  }
}




