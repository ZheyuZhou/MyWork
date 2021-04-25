package edu.illinois.cs.cs125.fall2020.mp.models;

/**
 * Rating class for starting client.
 */
public class Rating {
    /** Rating indicating that the course has no been rated yet. */
  public static final  double NOT_RATED = -1.0;
  private double rating;
  private String id;

  /**
   * default constructor.
   */
  public Rating() {};
    /**
     * constructor.
     * @param setId
     * @param setRating
     */
  public Rating(final String setId, final double setRating) {
    //throw new IllegalStateException("Not yet implemented");
    this.rating = setRating;
    this.id = setId;
  }
  /**
   * get the id of the client.
   * @return idk
   */
  public String getId() {
    //throw new IllegalStateException("Not yet implemented");
    return this.id;
  }

  /**
   * get the rating of the course.
   * @return idk
   */
  public double getRating() {
    //throw new IllegalStateException("Not yet implemented");
    return this.rating;
  }
}
