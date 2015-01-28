import com.datastax.driver.core.*;
import com.datastax.driver.core.policies.*;
import java.util.*;
import java.io.*;

public class ExecAsync10 {
  static String filename;
  static String host;
  static String keyspace = "test";
  static String table = "test10";
  static String delimiter = ",";
  static String insert = "INSERT INTO " + keyspace + "." + table + " (pkey, tstamp, c1, c2, c3, c4, c5, c6, c7, c8) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";

  public static void main(String[] args) throws IOException {
    if (args.length != 2) {
      System.err.println("Expecting 2 arguments: <filename> <ipaddress>");
      System.exit(1);
    }
    filename = args[0];
    host = args[1];

    BufferedReader reader = new BufferedReader(new FileReader(filename));
    File directory = new File(keyspace);
    if (!directory.exists())
      directory.mkdir();

    Cluster cluster = Cluster.builder()
                             .addContactPoint(host)
                             .withPort(9042)
                             .withLoadBalancingPolicy(new TokenAwarePolicy( new DCAwareRoundRobinPolicy()))
                             .build();
    Session session = cluster.newSession();

    PreparedStatement statement = session.prepare(insert);
    List<ResultSetFuture> futures = new ArrayList<ResultSetFuture>();

    CsvParser parser = new CsvParser();
    String line;
    int lineNumber = 1;
    while ((line = reader.readLine()) != null) {
      if (999 == lineNumber % 1000) {
        for (ResultSetFuture future: futures) {
          future.getUninterruptibly();
        }
        futures.clear();
      }
      if (parser.parse(line, delimiter, lineNumber)) {
        BoundStatement bind = statement.bind(parser.partkey, parser.tstamp, parser.col1, parser.col2, parser.col3, parser.col4, parser.col5, parser.col6, parser.col7, parser.col8);
        ResultSetFuture resultSetFuture = session.executeAsync(bind);
        futures.add(resultSetFuture);
      }
      lineNumber++;
    }

    for (ResultSetFuture future: futures) {
      future.getUninterruptibly();
    }
    futures.clear();

    cluster.close();
  }


  static class CsvParser {
    public long partkey;
    public long tstamp;
    public long col1;
    public long col2;
    public long col3;
    public long col4;
    public long col5;
    public long col6;
    public long col7;
    public long col8;
    static int numCols = 10;

    boolean parse(String line, String delimiter, int lineNumber) {
      String[] columns = line.split(delimiter);
      if (10 != columns.length) {
        System.err.println(String.format("Invalid input '%s' at line %d of %s", line, lineNumber, filename));
        return false;
      }
      try {
        partkey = Long.parseLong(columns[0].trim());
        tstamp = Long.parseLong(columns[1].trim());
        col1 = Long.parseLong(columns[2].trim());
        col2 = Long.parseLong(columns[3].trim());
        col3 = Long.parseLong(columns[4].trim());
        col4 = Long.parseLong(columns[5].trim());
        col5 = Long.parseLong(columns[6].trim());
        col6 = Long.parseLong(columns[7].trim());
        col7 = Long.parseLong(columns[8].trim());
        col8 = Long.parseLong(columns[9].trim());
        return true;
      }
      catch (NumberFormatException e) {
        System.err.println(String.format("Invalid number in input '%s' at line %d of %s", line, lineNumber, filename));
        return false;
      }
    }
  }
}

