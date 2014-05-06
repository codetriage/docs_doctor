require 'test_helper'

class ParsersYardTest < ActiveSupport::TestCase

  test "parses threaded" do
    repo    = Repo.where(full_name: "schneems/threaded").create!
    path    = fixture_path("repos/threaded")
    parser  = DocsDoctor::Parsers::Ruby::Yard.new(path)
    parser.process
    parser.store(repo)

    assert_equal 62, repo.doc_methods.count
    assert_equal 29, repo.doc_methods.missing_docs.count
    assert_equal 33, repo.doc_methods.with_docs.count
  end

  test "parses parts of rails" do
    repo    = repos(:rails_rails)
    path    = fixture_path("repos/rails_stubs/fixture_set_file.rb")
    parser  = DocsDoctor::Parsers::Ruby::Yard.new(path)
    parser.process
    parser.store(repo)

    doc = DocMethod.where(path: "ActiveRecord::FixtureSet::File#initialize").first
    assert doc.present?, "Expected ActiveRecord::FixtureSet::File#initialize to exist"
  end

end
