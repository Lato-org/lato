require "test_helper"

module Lato
  class ComponentableSearchTest < ActiveSupport::TestCase
    class SearchController < ActionController::Base
      include Lato::Componentable
      public :lato_index_search_condition
    end

    setup do
      @controller = SearchController.new
      base = { last_name: "Franco", password: "Password1!", accepted_privacy_policy_version: 1, accepted_terms_and_conditions_version: 1 }
      @percent = Lato::User.create!(base.merge(first_name: "100% Mario", email: "percent@mail.com"))
      @plain = Lato::User.create!(base.merge(first_name: "1000 Mario", email: "plain@mail.com"))
    end

    test "like wildcards typed by the user match literally" do
      result = Lato::User.where(@controller.lato_index_search_condition(Lato::User.all, [:first_name], "0%"))
      assert_includes result, @percent
      assert_not_includes result, @plain
    end

    test "search is case insensitive and casts non string columns" do
      result = Lato::User.where(@controller.lato_index_search_condition(Lato::User.all, [:first_name, :id], "MARIO"))
      assert_includes result, @plain
      assert_includes Lato::User.where(@controller.lato_index_search_condition(Lato::User.all, [:id], @plain.id.to_s)), @plain
    end
  end
end
