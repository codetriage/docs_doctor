require 'test_helper'

class ParsersYardTest < ActiveSupport::TestCase

  test "parses threaded" do
    repo    = Repo.where(full_name: "schneems/threaded").create!
    path    = fixture_path("repos/threaded")
    parser  = DocsDoctor::Parsers::Ruby::Yard.new(path)
    parser.process
    parser.store(repo)

    assert_equal 56, repo.doc_methods.count
    assert_equal 26, repo.doc_methods.missing_docs.count
    assert_equal 30, repo.doc_methods.with_docs.count
  end

end
