package edu.illinois.cs.cs125.fall2020.mp.models;

/**
 * Model holding the course summary information shown in the course list.
 * <p>You will need to complete this model for MP0.
 */
public class Course extends Summary {
  private String description;
    /**
     * Get the year for this Summary.
     * @return the year for this Summary
     */
  @SuppressWarnings("checkstyle:Indentation")
  public final String getDescription() {
    return description;
  }
}
