package edu.illinois.cs.cs125.fall2020.mp.network;

import android.util.Log;
import androidx.annotation.NonNull;

import com.android.volley.AuthFailureError;
import com.android.volley.Cache;
import com.android.volley.ExecutorDelivery;
import com.android.volley.Network;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.toolbox.BasicNetwork;
import com.android.volley.toolbox.HurlStack;
import com.android.volley.toolbox.NoCache;
import com.android.volley.toolbox.StringRequest;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import edu.illinois.cs.cs125.fall2020.mp.application.CourseableApplication;
import edu.illinois.cs.cs125.fall2020.mp.models.Course;
import edu.illinois.cs.cs125.fall2020.mp.models.Rating;
import edu.illinois.cs.cs125.fall2020.mp.models.Summary;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.concurrent.Executors;

/**
 * Course API client.
 *
 * <p>You will add functionality to the client as part of MP1 and MP2.
 */
public final class Client {
  private static final String TAG = Client.class.getSimpleName();
  private static final int INITIAL_CONNECTION_RETRY_DELAY = 1000;

  /**
   * Course API client callback interface.
   *
   * <p>Provides a way for the client to pass back information obtained from the course API server.
   */
  public interface CourseClientCallbacks {
    /**
     * Return course summaries for the given year and semester.
     *
     * @param year the year that was retrieved
     * @param semester the semester that was retrieved
     * @param summaries an array of course summaries
     */
    default void summaryResponse(String year, String semester, Summary[] summaries){}
    /**
     * Return course summaries for the given year and semester.
     *
     * @param summary idk
     * @param course idk
     */
    default void courseResponse(Summary summary, Course course) {}

    /**
     * callback function.
     * @param summary
     * @param rating
     */
    default void yourRating(Summary summary, Rating rating) { }

    /**
     * test i don;t know what.
     * @param theString
     */
    default void testPost(String theString) {}
  }

  /**
   * Retrieve course summaries for a given year and semester.
   *
   * @param year the year to retrieve
   * @param semester the semester to retrieve
   * @param callbacks the callback that will receive the result
   */
  public void getSummary(
      @NonNull final String year,
      @NonNull final String semester,
      @NonNull final CourseClientCallbacks callbacks) {
    String url = CourseableApplication.SERVER_URL + "summary/" + year + "/" + semester;
    StringRequest summaryRequest =
        new StringRequest(
            Request.Method.GET,
            url,
            response -> {
              try {
                Summary[] courses = objectMapper.readValue(response, Summary[].class);
                callbacks.summaryResponse(year, semester, courses);
              } catch (JsonProcessingException e) {
                e.printStackTrace();
              }
            },
            error -> Log.e(TAG, error.toString()));
    requestQueue.add(summaryRequest);
  }

  /**
   * set the string.
   * @param theString
   * @param callbacks
   */
  public void setString(
          @NonNull final String theString,
          @NonNull final CourseClientCallbacks callbacks) {
    String url = CourseableApplication.SERVER_URL + "test/";
    StringRequest summaryRequest =
        new StringRequest(
                    Request.Method.POST,
                    url,
                    response -> callbacks.testPost(theString),
                    error -> Log.e(TAG, error.toString())) {
        @Override
        public byte[] getBody() throws AuthFailureError {
          return theString.getBytes();
      }
    };
    requestQueue.add(summaryRequest);
  }

  /**
   * get the string.
   * @param callbacks
   */
  public void getString(
          @NonNull final CourseClientCallbacks callbacks) {
    String url = CourseableApplication.SERVER_URL + "test/";
    StringRequest summaryRequest =
            new StringRequest(
                    Request.Method.GET,
                    url,
                    response -> callbacks.testPost(response.toString()),
                    error -> Log.e(TAG, error.toString()));
    requestQueue.add(summaryRequest);
  }
  /**
   * Return course summaries for the given year and semester.
   *
   * @param summary the year that was retrieved
   * @param callbacks the semester that was retrieved
   */
  public void getCourse(
      @NonNull final Summary summary,
      @NonNull final CourseClientCallbacks callbacks) {
    String url = CourseableApplication.SERVER_URL + "course/" + summary.getYear() + "/" + summary.getSemester()
            + "/" + summary.getDepartment() + "/" + summary.getNumber();
    StringRequest summaryRequest =
            new StringRequest(
                    Request.Method.GET,
                    url,
                    response -> {
                      try {
                        Course insideC = objectMapper.readValue(response, Course.class);
                        callbacks.courseResponse(summary, insideC);
                      } catch (JsonProcessingException e) {
                        e.printStackTrace();
                      }
                    },
                    error -> Log.e(TAG, error.toString()));
    requestQueue.add(summaryRequest);

  }

  /**
   * get the rating.
   * @param summary
   * @param clientID
   * @param callbacks
   */
  public void getRating(
          @NonNull final Summary summary, @NonNull final String clientID, @NonNull final CourseClientCallbacks callbacks
  ) {
    String y = summary.getYear();
    String d = summary.getDepartment();
    String n = summary.getNumber();
    String s = summary.getSemester();
    String url = CourseableApplication.SERVER_URL + "rating/" + y + "/" + s
            + "/" + d + "/" + n + "?client=" + clientID;
    StringRequest ratingRequest =
            new StringRequest(
                    Request.Method.GET,
                    url,
                    response -> {
                      try {
                        Rating r = objectMapper.readValue(response, Rating.class);
                        callbacks.yourRating(summary, r);
                      } catch (JsonProcessingException e) {
                        e.printStackTrace();
                      }
                    },
                    error -> Log.e(TAG, error.toString()));
    requestQueue.add(ratingRequest);
  }

  private static final ObjectMapper HELP = new ObjectMapper();
  /**
   * post the ratings.
   * @param summary
   * @param rating
   * @param callbacks
   */
  public void postRating(
          @NonNull final Summary summary, @NonNull final Rating rating, @NonNull final CourseClientCallbacks callbacks
  ) {
    String y = summary.getYear();
    String d = summary.getDepartment();
    String n = summary.getNumber();
    String s = summary.getSemester();
    String idd = rating.getId();
    String url = CourseableApplication.SERVER_URL + "rating/" + y + "/" + s
            + "/" + d + "/" + n + "?client=" + idd;
    StringRequest pratingRequest =
            new StringRequest(
                    Request.Method.POST,
                    url,
                    response -> callbacks.yourRating(summary, rating),
                    error -> Log.e(TAG, error.toString())) {
      @Override
              public byte[] getBody() throws AuthFailureError {
        try {
          return HELP.writeValueAsString(rating).getBytes();
        } catch (JsonProcessingException e) {
          e.printStackTrace();
          return null;
        }
      }
    };
    requestQueue.add(pratingRequest);
  }

  private static Client instance;
  /**
   * Retrieve the course API client. Creates one if it does not already exist.
   *
   * @return the course API client
   */
  public static Client start() {
    if (instance == null) {
      instance = new Client();
    }
    return instance;
  }

  private static final int MAX_STARTUP_RETRIES = 8;
  private static final int THREAD_POOL_SIZE = 4;

  private final ObjectMapper objectMapper = new ObjectMapper();
  private final RequestQueue requestQueue;

  /*
   * Set up our client, create the Volley queue, and establish a backend connection.
   */
  private Client() {
    // Configure the Volley queue used for our network requests
    Cache cache = new NoCache();
    Network network = new BasicNetwork(new HurlStack());
    HttpURLConnection.setFollowRedirects(true);
    requestQueue = new RequestQueue(
            cache, network, THREAD_POOL_SIZE, new ExecutorDelivery(Executors.newSingleThreadExecutor())
    );

    // Configure the Jackson object mapper to ignore unknown properties
    objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

    // Make sure the backend URL is valid
    URL serverURL;
    try {
      serverURL = new URL(CourseableApplication.SERVER_URL);
    } catch (MalformedURLException e) {
      Log.e(TAG, "Bad server URL: " + CourseableApplication.SERVER_URL);
      return;
    }

    // Start a background thread to establish the server connection
    new Thread(
            () -> {
              for (int i = 0; i < MAX_STARTUP_RETRIES; i++) {
                try {
                  // Issue a HEAD request for the root URL
                  HttpURLConnection connection = (HttpURLConnection) serverURL.openConnection();
                  connection.setRequestMethod("HEAD");
                  connection.connect();
                  connection.disconnect();
                  // Once this succeeds, we can start the Volley queue
                  requestQueue.start();
                  break;
                } catch (Exception e) {
                  Log.e(TAG, e.toString());
                }
                // If the connection fails, delay and then retry
                try {
                  Thread.sleep(INITIAL_CONNECTION_RETRY_DELAY);
                } catch (InterruptedException ignored) {
                }
              }
            })
        .start();
  }
}