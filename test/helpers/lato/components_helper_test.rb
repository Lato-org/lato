require "test_helper"

module Lato
  class ComponentsHelperTest < ActionView::TestCase
    include Lato::ComponentsHelper

    test "page head escapes the title" do
      html = lato_page_head("<img src=x onerror=alert(1)>")
      assert_not_includes html, "<img src=x"
      assert_includes html, "&lt;img src=x onerror=alert(1)&gt;"
    end

    test "page head keeps html_safe titles" do
      assert_includes lato_page_head("<em>Title</em>".html_safe), "<em>Title</em>"
    end

    test "checkbox label targets the checkbox id and escapes unsafe labels" do
      html = form_with(model: Lato::User.new, url: "/") do |form|
        lato_form_item_input_check(form, :accepted_privacy_policy_version, "<b>Accept</b>")
      end
      document = Nokogiri::HTML.fragment(html)
      checkbox = document.at_css("input[type=checkbox]")
      assert_equal checkbox["id"], document.at_css("label.form-check-label")["for"]
      assert_includes html, "&lt;b&gt;Accept&lt;/b&gt;"
    end

    test "errored inputs are marked invalid and linked to an inline message" do
      user = Lato::User.new
      user.errors.add(:email, :blank)
      html = form_with(model: user, url: "/") { |form| lato_form_item_input_email(form, :email) }
      document = Nokogiri::HTML.fragment(html)
      input = document.at_css("input[type=email]")
      assert_equal "true", input["aria-invalid"]
      feedback = document.at_css("##{input['aria-describedby']}")
      assert_equal "invalid-feedback", feedback["class"]
      assert_equal user.errors[:email].to_sentence, feedback.text
    end

    test "inputs without errors have no aria-invalid" do
      html = form_with(model: Lato::User.new, url: "/") { |form| lato_form_item_input_email(form, :email) }
      assert_nil Nokogiri::HTML.fragment(html).at_css("input")["aria-invalid"]
    end

    test "data user renders the image url as an escaped attribute" do
      html = lato_data_user("Name", "https://example.com/a.png); background:url(//evil")
      assert_not_includes html, "background-image"
      assert_equal "https://example.com/a.png); background:url(//evil", Nokogiri::HTML.fragment(html).at_css("img")["src"]
    end
  end
end
