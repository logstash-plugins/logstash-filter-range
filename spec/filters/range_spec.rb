require "logstash/devutils/rspec/spec_helper"
require "insist"
require "logstash/filters/range"

describe LogStash::Filters::Range do
  

  describe "range match integer field on tag action" do
    config <<-CONFIG
      filter {
        range {
          ranges => [ "duration", 10, 100, "tag:cool",
                      "duration", 1, 1, "tag:boring" ]
        }
      }
    CONFIG

    sample("duration" => 50) do
      insist { subject.get("tags") }.include?("cool")
      reject { subject.get("tags") }.include?("boring")
    end
  end

  describe "range match float field on tag action" do
    config <<-CONFIG
      filter {
        range {
          ranges => [ "duration", 0, 100, "tag:cool",
                      "duration", 0, 1, "tag:boring" ]
        }
      }
    CONFIG

    sample("duration" => 50.0) do
      insist { subject.get("tags") }.include?("cool")
      reject { subject.get("tags") }.include?("boring")
    end
  end

  describe "range match string field on tag action" do
    config <<-CONFIG
      filter {
        range {
          ranges => [ "length", 0, 10, "tag:cool",
                      "length", 0, 1, "tag:boring" ]
        }
      }
    CONFIG

    sample("length" => "123456789") do
      insist { subject.get("tags") }.include?("cool")
      reject { subject.get("tags") }.include?("boring")
    end
  end

  describe "range match with negation" do
    config <<-CONFIG
      filter {
        range {
          ranges => [ "length", 0, 10, "tag:cool",
                      "length", 0, 1, "tag:boring" ]
          negate => true
        }
      }
    CONFIG

    sample("length" => "123456789") do
      reject { subject.get("tags") }.include?("cool")
      insist { subject.get("tags") }.include?("boring")
    end
  end

  describe "range match on drop action" do
    config <<-CONFIG
      filter {
        range {
          ranges => [ "length", 0, 10, "drop" ]
        }
      }
    CONFIG

    sample("length" => "123456789") do
      insist { subject }.nil?
    end
  end

  describe "range match on field action with string value" do
    config <<-CONFIG
      filter {
        range {
          ranges => [ "duration", 10, 100, "field:cool:foo",
                      "duration", 1, 1, "field:boring:foo" ]
        }
      }
    CONFIG

    sample("duration" => 50) do
      insist { subject }.include?("cool")
      insist { subject.get("cool") } == "foo"
      reject { subject }.include?("boring")
    end
  end

  describe "range match on field action with integer value" do
    config <<-CONFIG
      filter {
        range {
          ranges => [ "duration", 10, 100, "field:cool:666",
                      "duration", 1, 1, "field:boring:666" ]
        }
      }
    CONFIG

    sample("duration" => 50) do
      insist { subject }.include?("cool")
      insist { subject.get("cool") } == 666
      reject { subject }.include?("boring")
    end
  end

  describe "range match on field action with float value" do
    config <<-CONFIG
      filter {
        range {
          ranges => [ "duration", 10, 100, "field:cool:3.14",
                      "duration", 1, 1, "field:boring:3.14" ]
        }
      }
    CONFIG

    sample("duration" => 50) do
      insist { subject }.include?("cool")
      insist { subject.get("cool") } == 3.14
      reject { subject }.include?("boring")
    end
  end

  describe "range match on tag action with dynamic string value" do
    config <<-CONFIG
      filter {
        range {
          ranges => [ "duration", 10, 100, "tag:cool_%{dynamic}_dynamic",
                      "duration", 1, 1, "tag:boring_%{dynamic}_dynamic" ]
        }
      }
    CONFIG

    sample("duration" => 50, "dynamic" => "and") do
      insist { subject.get("tags") }.include?("cool_and_dynamic")
      reject { subject.get("tags") }.include?("boring_and_dynamic")
    end
  end

  describe "range match on field action with dynamic string field and value" do
    config <<-CONFIG
      filter {
        range {
          ranges => [ "duration", 10, 100, "field:cool_%{dynamic}_dynamic:foo_%{dynamic}_bar",
                      "duration", 1, 1, "field:boring_%{dynamic}_dynamic:foo_%{dynamic}_bar" ]
        }
      }
    CONFIG

    sample("duration" => 50, "dynamic" => "and") do
      insist { subject }.include?("cool_and_dynamic")
      insist { subject.get("cool_and_dynamic") } == "foo_and_bar"
      reject { subject }.include?("boring_and_dynamic")
    end
  end
end
