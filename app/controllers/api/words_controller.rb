class Api::WordsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    render json: Word.order(:id).preload(:definitions).page(params[:page]).to_json(:include => :definitions)
  end

  def create
    @word = Word.new(word: params[:word],
                     part_of_speech: params[:part_of_speech])

    if params.has_key?(:definitions)
      definition = Definition.new(definition: params[:definitions][0][:definition])
      @word.definitions << definition
    end

    if @word.save
      render json: @word, status: :ok
    else
      payload = { error: "error creating word", status: 400 }
      render :json => payload, :status => :bad_request
    end
  end

  def show
    render json: Word.where(id: params[:id]).includes(:definitions).first.to_json(:include => :definitions)
  end
end
