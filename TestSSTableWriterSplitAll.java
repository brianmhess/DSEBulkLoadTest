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

public class TestSSTableWriterSplitAll {
  static String filename;
  static String outdir;
  static String ip = "127.0.0.1";
  static String keyspace = "";
  static String table = "";
  static String delimiter = ",";
  static String schema = "";
  static String insert = "";
  static String dummyString = "";
  static long dummyLong = 0;

  static Cluster cluster;
  static Session session;
  static Metadata metadata;
  static PreparedStatement stmt;

  private static void init() {
    cluster = Cluster.builder().addContactPoint(ip).build();
    metadata = cluster.getMetadata();
    session = cluster.newSession();
    stmt = session.prepare(insert);
  }

  private static void cleanup() {
    session.close();
    cluster.close();
  }

  public static void main(String[] args) throws IOException {
    if (args.length != 5) {
      System.err.println("Expecting 5 arguments: <filename> <output directory> <keyspace> <tablename> <IP address>");
      System.exit(1);
    }
    filename = args[0];
    outdir = args[1];
    keyspace = args[2];
    table = args[3];
    ip = args[4];
    CsvParser parser = new CsvParser();
    schema = "CREATE TABLE IF NOT EXISTS " + keyspace + "." + table + " (pkey TEXT, ccol BIGINT, data TEXT, PRIMARY KEY ((pkey), ccol));";
    insert = "INSERT INTO " + keyspace + "." + table + " (pkey, ccol, data) VALUES (?, ?, ?);";

    System.err.println("*******A");
    init();
    System.err.println("*******b");

    Config.setClientMode(true);
    BufferedReader reader = new BufferedReader(new FileReader(filename));
    Map<String,CQLSSTableWriter> map = new HashMap<String,CQLSSTableWriter>();
    System.err.println("*******C");
    System.err.println("Hosts: " + metadata.getAllHosts());
    for (Host h : metadata.getAllHosts()) {
      String sip = h.getAddress().getHostAddress();
      String sipdir = outdir + "/" + sip;
      System.err.println("sipdir = " + sipdir);
      File directory = new File(sipdir);
      if (!directory.exists())
        directory.mkdirs();

      CQLSSTableWriter writer = CQLSSTableWriter.builder().inDirectory(sipdir).forTable(schema).using(insert).build();
      map.put(sip, writer);
    }
    System.err.println("*******D");


    String line;
    int lineNumber = 1;
    long timestamp = System.currentTimeMillis() * 1000;

    while ((line = reader.readLine()) != null) {
      if (parser.parse(line, delimiter, lineNumber)) {
//        if (0 == lineNumber % 10000)
//          System.err.println("Got to line " + lineNumber);
        BoundStatement bind = stmt.bind(parser.pkey, dummyLong, dummyString);
        ByteBuffer bb = bind.getBytesUnsafe(0);
        Set<Host> endpts = metadata.getReplicas(keyspace, bb);
        for (Host h : endpts) {
          parser.addRow(map.get(h.getAddress().getHostAddress()));
        }
      }
      lineNumber++;
    }

    cleanup();

    for (CQLSSTableWriter w : map.values())
      w.close();
    System.exit(0);
  }

  static class CsvParser {
    public String pkey;
    public long ccol;
    public String data;

    boolean parse(String line, String delimiter, int lineNumber) {
      String[] columns = line.split(delimiter);
      if (3 != columns.length) {
        System.err.println(String.format("Invalid input '%s' at line %d of %s", line, lineNumber, filename));
        return false;
      }
      try {
        pkey = columns[0].trim();
        ccol = Long.parseLong(columns[1].trim());
        data = columns[2].trim();
        return true;
      }
      catch (NumberFormatException e) {
        System.err.println(String.format("Invalid number in input '%s' at line %d of %s", line, lineNumber, filename));
        return false;
      }
    }
    void addRow(CQLSSTableWriter writer) {
      try {
        writer.addRow(pkey, ccol, data);
      }
      catch (Exception e) {
        System.err.println("Couldn't addRow: " + e.getMessage());
      }
    }
  }

//  public static void main(String [] args) throws IOException {
//    System.err.println("++++++");
//    TestSSTableWriterSplit n = new TestSSTableWriterSplit();
//    n.run(args);
//  }
}




