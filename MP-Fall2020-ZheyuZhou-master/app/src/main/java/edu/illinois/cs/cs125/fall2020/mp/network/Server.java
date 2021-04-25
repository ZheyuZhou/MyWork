package edu.illinois.cs.cs125.fall2020.mp.network;

import androidx.annotation.NonNull;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import edu.illinois.cs.cs125.fall2020.mp.application.CourseableApplication;
import edu.illinois.cs.cs125.fall2020.mp.models.Rating;
import edu.illinois.cs.cs125.fall2020.mp.models.Summary;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Objects;
import java.util.Scanner;
import okhttp3.mockwebserver.Dispatcher;
import okhttp3.mockwebserver.MockResponse;
import okhttp3.mockwebserver.MockWebServer;
import okhttp3.mockwebserver.RecordedRequest;


/**
 * Development course API server.
 *
 * <p>Normally you would run this server on another machine, which the client would connect to over
 * the internet. For the sake of development, we're running the server right alongside the app on
 * the same device. However, all communication between the course API client and course API server
 * is still done using the HTTP protocol. Meaning that eventually it would be straightforward to
 * move this server to another machine where it could provide data for all course API clients.
 *
 * <p>You will need to add functionality to the server for MP1 and MP2.
 */

public final class Server extends Dispatcher {
  @SuppressWarnings({"unused", "RedundantSuppression"})
  private static final String TAG = Server.class.getSimpleName();

  private final Map<String, String> summaries = new HashMap<>();
  //summary/2020/fall



  private MockResponse getSummary(@NonNull final String path) {
    String[] parts = path.split("/");
    if (parts.length != 2) {
      return new MockResponse().setResponseCode(HttpURLConnection.HTTP_BAD_REQUEST);
    }
    String summary = summaries.get(parts[0] + "_" + parts[1]);
    if (summary == null) {
      return new MockResponse().setResponseCode(HttpURLConnection.HTTP_NOT_FOUND);
    }
    return new MockResponse().setResponseCode(HttpURLConnection.HTTP_OK).setBody(summary);
  }

  //Create a hashmap and format as <course summary<clientid,rating>>.
  private static final ObjectMapper HELP = new ObjectMapper();
  private final Map<Summary, Map<String, Rating>> rateCourse = new HashMap<>();
  private MockResponse yourRating(@NonNull final String path, @NonNull final RecordedRequest request)
          throws JsonProcessingException {
    //rating/2020/fall/CS/888?client=79137a60-19a5-405b-8a6e-65f48c0b5400
    if (Objects.requireNonNull(request.getMethod()).equals("GET")) {
      String[] parts = path.split("/");
      if (parts.length != 3 + 1) {
        return new MockResponse().setResponseCode(HttpURLConnection.HTTP_BAD_REQUEST);
      }
      String year = parts[0];
      String semester = parts[1];
      String department = parts[2];
      String zzy = parts[3];
      String[] newparts = zzy.split("=");
      if (newparts.length != 2) {
        return new MockResponse().setResponseCode(HttpURLConnection.HTTP_BAD_REQUEST);
      }
      String number = newparts[0];
      String id = newparts[1];
      int lastindex = number.indexOf("?");
      String idd = number.substring(0, lastindex);
      Summary description = new Summary(year, semester, department, idd, "");
      //see if the course exists
      if (courses.get(description) == null) {
        System.out.println("no such course?");
        return new MockResponse().setResponseCode(HttpURLConnection.HTTP_NOT_FOUND);
      }
      System.out.println("yes such course!");
      //is the course exist, get the client->rating map
      Map<String, Rating> clientToRate = rateCourse.get(description);
      assert clientToRate != null;
      Rating courseRate = clientToRate.get(id);
      //see if the client rated the course
      //the course has not been rated by the specific client
      if (courseRate == null) {
        System.out.println("no such rate?");
        courseRate = new Rating(id, -1.0);
        return new MockResponse().setResponseCode(HttpURLConnection.HTTP_OK)
                .setBody(HELP.writeValueAsString(courseRate));
      }
      System.out.println("has rate");
      // the course has been rated by the specific client
      return new MockResponse().setResponseCode(HttpURLConnection.HTTP_OK).setBody(HELP.writeValueAsString(courseRate));
    } else if (request.getMethod().equals("POST")) {
      String requestStr = request.getBody().readUtf8();
      Rating crate = null;
      try {
        crate = mapper.readValue(requestStr, Rating.class);
      } catch (JsonProcessingException e) {
        e.printStackTrace();
      }
      if (crate == null) {
        return new MockResponse().setResponseCode(HttpURLConnection.HTTP_BAD_REQUEST);
      }
      String[] parts = path.split("/");
      if (parts.length != 3 + 1) {
        return new MockResponse().setResponseCode(HttpURLConnection.HTTP_BAD_REQUEST);
      }
      String year = parts[0];
      String semester = parts[1];
      String department = parts[2];
      String zzy = parts[3];
      String[] newparts = zzy.split("=");
      if (newparts.length != 2) {
        return new MockResponse().setResponseCode(HttpURLConnection.HTTP_BAD_REQUEST);
      }
      String number = newparts[0];
      String id = newparts[1];
      int lastindex = number.indexOf("?");
      String idd = number.substring(0, lastindex);
      Summary description = new Summary(year, semester, department, idd, "");
      if (courses.get(description) == null) {
        System.out.println("no such course?");
        return new MockResponse().setResponseCode(HttpURLConnection.HTTP_NOT_FOUND);
      }
      System.out.println("yes such course!");
      Map<String, Rating> clientToRate = rateCourse.get(description);
      assert clientToRate != null;
      clientToRate.put(id, crate);
      return new MockResponse().setResponseCode(HttpURLConnection.HTTP_MOVED_TEMP).setHeader(
              "Location", "/rating/" + path);
    }
    return null;
  }





  private String theString = "";
  private MockResponse testPost(@NonNull final RecordedRequest request) {
    if (request.getMethod().equals("GET")) {
      return new MockResponse().setResponseCode(HttpURLConnection.HTTP_OK).setBody(theString);
    } else if (request.getMethod().equals("POST")) {
      theString = request.getBody().readUtf8();
      return new MockResponse().setResponseCode(HttpURLConnection.HTTP_OK);
    }
    return new MockResponse().setResponseCode(HttpURLConnection.HTTP_BAD_REQUEST);
  }

  @SuppressWarnings("MismatchedQueryAndUpdateOfCollection")
  private final Map<Summary, String> courses = new HashMap<>();
  //course/2020/fall/CS/125
  private MockResponse getCourse(@NonNull final String path) {

    System.out.println((path));
    String[] parts = path.split("/");
    if (parts.length != 3 + 1) {
      return new MockResponse().setResponseCode(HttpURLConnection.HTTP_BAD_REQUEST);
    }
    String year = parts[0];
    String semester = parts[1];
    String depart = parts[2];
    String numb = parts[3];
    Summary a = new Summary(year, semester, depart, numb, " ");
    String value = courses.get(a);

    if (value == null) {
      return new MockResponse().setResponseCode(HttpURLConnection.HTTP_NOT_FOUND);
    }
    return new MockResponse().setResponseCode(HttpURLConnection.HTTP_OK).setBody(value);
  }


  @NonNull
  @Override
  public MockResponse dispatch(@NonNull final RecordedRequest request) {
    try {
      String path = request.getPath();
      if (path == null || request.getMethod() == null) {
        return new MockResponse().setResponseCode(HttpURLConnection.HTTP_NOT_FOUND);
      } else if (path.equals("/") && request.getMethod().equalsIgnoreCase("HEAD")) {
        return new MockResponse().setResponseCode(HttpURLConnection.HTTP_OK);
      } else if (path.startsWith("/course/")) {
        return getCourse(path.replaceFirst("/course/", ""));
      } else if (path.startsWith("/summary/")) {
        return getSummary(path.replaceFirst("/summary/", ""));
      } else if (path.startsWith("/rating/")) {
        return yourRating(path.replaceFirst("/rating/", ""), request);
      } else if (path.equals("/test/")) {
        return testPost(request);
      }
      return new MockResponse().setResponseCode(HttpURLConnection.HTTP_NOT_FOUND);
    } catch (Exception e) {
      return new MockResponse().setResponseCode(HttpURLConnection.HTTP_INTERNAL_ERROR);
    }
  }

  private static boolean started = false;

  /**
   * Start the server if has not already been started.
   *
   * <p>We start the server in a new thread so that it operates separately from and does not
   * interfere with the rest of the app.
   */
  public static void start() {
    if (!started) {
      new Thread(Server::new).start();
      started = true;
    }
  }

  private final ObjectMapper mapper = new ObjectMapper();

  private Server() {
    mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

    loadSummary("2020", "fall");
    loadCourses("2020", "fall");
    for (Summary summ : courses.keySet()) {
      rateCourse.put(summ, new HashMap<String, Rating>());
    }
    try {
      MockWebServer server = new MockWebServer();
      server.setDispatcher(this);
      server.start(CourseableApplication.SERVER_PORT);

      String baseUrl = server.url("").toString();
      if (!CourseableApplication.SERVER_URL.equals(baseUrl)) {
        throw new IllegalStateException("Bad server URL: " + baseUrl);
      }
    } catch (IOException e) {
      throw new IllegalStateException(e.getMessage());
    }
  }

  @SuppressWarnings("SameParameterValue")
  private void loadSummary(@NonNull final String year, @NonNull final String semester) {
    String filename = "/" + year + "_" + semester + "_summary.json";
    String json =
            new Scanner(Server.class.getResourceAsStream(filename), "UTF-8").useDelimiter("\\A").next();
    summaries.put(year + "_" + semester, json);
  }

  @SuppressWarnings("SameParameterValue")
  private void loadCourses(@NonNull final String year, @NonNull final String semester) {
    String filename = "/" + year + "_" + semester + ".json";
    String json =
            new Scanner(Server.class.getResourceAsStream(filename), "UTF-8").useDelimiter("\\A").next();
    try {
      JsonNode nodes = mapper.readTree(json);
      for (Iterator<JsonNode> it = nodes.elements(); it.hasNext(); ) {
        JsonNode node = it.next();
        Summary course = mapper.readValue(node.toString(), Summary.class);
        courses.put(course, node.toPrettyString());
      }
    } catch (JsonProcessingException e) {
      throw new IllegalStateException(e);
    }
  }
}

