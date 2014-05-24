require 'test_helper'

class ParsersYardTest < ActiveSupport::TestCase

  test "parses threaded" do
    repo    = repos(:threaded)
    path    = fixture_path("repos/threaded")
    parser  = DocsDoctor::Parsers::Ruby::Yard.new(path)
    parser.process
    parser.store(repo)

    assert_equal 56, repo.doc_methods.count
    assert_equal 26, repo.doc_methods.missing_docs.count
    assert_equal 30, repo.doc_methods.with_docs.count
  end

  test "parses parts of rails" do
    repo    = repos(:rails_rails)
    path    = fixture_path("repos/fixture_set_file/")
    parser  = DocsDoctor::Parsers::Ruby::Yard.new(path)
    parser.process
    parser.store(repo)

    doc = DocMethod.where(path: "ActiveRecord::FixtureSet::File#initialize").first
    assert doc.present?, "Expected ActiveRecord::FixtureSet::File#initialize to exist"
  end

  test "class_method" do
    repo   = repos(:threaded)
    path   = fixture_path("repos/class_method")
    parser = DocsDoctor::Parsers::Ruby::Yard.new(path)
    parser.process
    parser.store(repo)
    assert_equal 1, repo.doc_methods.count, "ClassMethod not properly parsed"
    assert_equal "ClassMethod.foo", repo.doc_methods.first.try(:path)
  end

  test ".document" do
    repo = repos(:threaded)
    path = fixture_path("repos/dot-document")
    parser  = DocsDoctor::Parsers::Ruby::Yard.new(path)
    parser.process
    parser.store(repo)
    err_msg = "did not read .document correctly: #{repo.doc_methods.all.inspect}"
    assert_equal 1, repo.doc_methods.count, err_msg
    assert_equal 1, repo.doc_methods.where(path: "#include").count, err_msg
    assert_equal 0, repo.doc_methods.where(path: "#exclude").count, err_msg
  end

  test ".yardopts" do
    repo    = repos(:threaded)
    path    = fixture_path("repos/dot-yardopts")
    parser  = DocsDoctor::Parsers::Ruby::Yard.new(path)
    parser.process
    parser.store(repo)
    err_msg = "did not read .document correctly: #{repo.doc_methods.all.inspect}"
    assert_equal 1, repo.doc_methods.count, err_msg
    assert_equal 1, repo.doc_methods.where(path: "#include").count, err_msg
    assert_equal 0, repo.doc_methods.where(path: "#exclude").count, err_msg
  end

end
