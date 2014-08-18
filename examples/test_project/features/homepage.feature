Feature: Verify and validate Google search engine's homepage

  Background: Launching homepage
    Given I am on the Google "Search" page

  @Ad
  Scenario: Verify 'Search' page elements
    Then I should see "Google" logo