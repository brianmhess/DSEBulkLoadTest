import com.datastax.driver.core.*;
import com.datastax.driver.core.policies.*;
import java.util.*;
import java.io.*;

public class ExecAsync {
  static String filename;
  static String host;
  static String keyspace = "test";
  static String table = "testb";
  static String delimiter = ",";
  static String insert = "INSERT INTO " + keyspace + "." + table + " (pkey, ccol, data) VALUES (?, ?, ?);";

  public static void main(String[] args) throws IOException {
    if (args.length != 3) {
      System.err.println("Expecting 2 arguments: <filename> <ipaddress> <tablename>");
      System.exit(1);
    }
    filename = args[0];
    host = args[1];
    table = args[2];

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
        BoundStatement bind = statement.bind(parser.pkey, parser.ccol, parser.data);
        ResultSetFuture resultSetFuture = session.executeAsync(bind);
        futures.add(resultSetFuture);
      }
      lineNumber++;
    }

    for (ResultSetFuture future: futures) {
      future.getUninterruptibly();
    }
    futures.clear();

    System.err.println("*** DONE: " + filename);

    cluster.close();
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
  }
}

