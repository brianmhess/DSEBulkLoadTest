import java.nio.ByteBuffer;
import java.io.*;
import java.util.UUID;
import org.apache.cassandra.io.sstable.CQLSSTableWriter;
import org.apache.cassandra.exceptions.InvalidRequestException;
import org.apache.cassandra.config.Config;

public class TestSSTableWriter {
  static String filename;
  static String outdir;
  static String keyspace = "test";
  static String table = "testb";
  static String delimiter = ",";
  public static void main(String[] args) throws IOException {
    if (args.length != 3) {
      System.err.println("Expecting 2 arguments: <filename> <output directory> <tablename>");
      System.exit(1);
    }
    filename = args[0];
    outdir = args[1];
    table = args[2];
    System.err.println("filename=" + filename + "  outdir=" + outdir + "  table=" + table);
    String schema = "CREATE TABLE IF NOT EXISTS " + keyspace + "." + table + " (pkey TEXT, ccol BIGINT, data TEXT, PRIMARY KEY ((pkey), ccol));";
    String insert = "INSERT INTO " + keyspace + "." + table + " (pkey, ccol, data) VALUES (?, ?, ?);";
    Config.setClientMode(true);
    BufferedReader reader = new BufferedReader(new FileReader(filename));
    File directory = new File(keyspace);
    if (!directory.exists())
      directory.mkdir();
    CsvParser parser = new CsvParser();
    CQLSSTableWriter writer = CQLSSTableWriter.builder().inDirectory(outdir).forTable(schema).using(insert).build();
    String line;
    int lineNumber = 1;
    long timestamp = System.currentTimeMillis() * 1000;
    while ((line = reader.readLine()) != null) {
      if (parser.parse(line, delimiter, lineNumber)) {
        parser.addRow(writer);
      }
      lineNumber++;
    }
    writer.close();
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
}

