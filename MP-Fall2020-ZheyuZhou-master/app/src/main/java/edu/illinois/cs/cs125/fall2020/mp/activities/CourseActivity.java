package edu.illinois.cs.cs125.fall2020.mp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.RatingBar;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.databinding.DataBindingUtil;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;


import edu.illinois.cs.cs125.fall2020.mp.R;

import edu.illinois.cs.cs125.fall2020.mp.application.CourseableApplication;
import edu.illinois.cs.cs125.fall2020.mp.databinding.ActivityCourseBinding;

import edu.illinois.cs.cs125.fall2020.mp.models.Course;
import edu.illinois.cs.cs125.fall2020.mp.models.Summary;
import edu.illinois.cs.cs125.fall2020.mp.models.Rating;
import edu.illinois.cs.cs125.fall2020.mp.network.Client;

/**
 * Create a Summary with the provided fields.
 */
public class CourseActivity extends AppCompatActivity implements Client.CourseClientCallbacks {
  private static final String TAG = CourseActivity.class.getSimpleName();
  private ActivityCourseBinding binding;
  private RatingBar rb;
  /**
   * Create a Summary with the provided fields.
   * add final not sure !!!!!!!!!!!!!--------------------cth
   * @param savedInstanceState      idk!
   */
  @Override
  protected void onCreate(@Nullable final Bundle savedInstanceState) {
    Log.i(TAG, "Course Activity Started");
    super.onCreate(savedInstanceState);
    binding = DataBindingUtil.setContentView(this, R.layout.activity_course);
    Intent intent = getIntent();
    String zzy = intent.getStringExtra("COURSE");
    if (zzy == null) {
      System.out.println("why???");
    }
    try {
      ObjectMapper stringToClass = new ObjectMapper();
      CourseableApplication app = (CourseableApplication) getApplication();
      Course temp = stringToClass.readValue(zzy, Course.class);
      app.getCourseClient().getCourse(temp, this);
      String clientid = app.getClientID();
      app.getCourseClient().getRating(temp, clientid, this);
      rb = (RatingBar) findViewById(R.id.rating);
      rb.setOnRatingBarChangeListener(new RatingBar.OnRatingBarChangeListener() {
        @Override
        public void onRatingChanged(final RatingBar ratingBar, final float rating, final boolean fromUser) {
          Rating r = new Rating(clientid, rating);
          app.getCourseClient().postRating(temp, r, CourseActivity.this);
        }
      });
    } catch (JsonMappingException e) {
      e.printStackTrace();
    } catch (JsonProcessingException e) {
      e.printStackTrace();
    }




  }


  /**
   * Callback called when the client has retrieved the list of courses for this component to
   * display.
   *
   * @param summary the year that was retrieved
   * @param course the semester that was retrieved
   */
  @Override
  public void courseResponse(final Summary summary, final Course course) {
    //System.out.println((course.getDescription()));
    binding.title.setText(course.getTitle());
    binding.description.setText(course.getDescription());
  }

  /**
   * get rating.
   * @param summary idk
   * @param rating idk
   */
  @Override
  public void yourRating(final Summary summary, final Rating rating) {
    //System.out.println((course.getDescription()));
    rb = (RatingBar) findViewById(R.id.rating);
    rb.setRating((float) rating.getRating());
  }

}
