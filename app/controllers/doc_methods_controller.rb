class DocMethodsController < ApplicationController
  def show
    @doc = DocMethod.find(params[:id])
  end
end