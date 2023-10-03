class WordsController < ApplicationController
  def index
    @words = Word.order(:id).page params[:page]
  end

  def show
    search_by = params[:id]

    if (search_by.to_i > 0)
      @word = Word.find(search_by)
    else
      @word = Word.where(word: search_by.capitalize).includes(:definitions).first
      if @word.nil? #try one more time w/o capitalization (this is a data error on my part)
        @word = Word.where(word: search_by).includes(:definitions).first
      end
    end
  end

  def new
    @word = Word.new
  end

  def create
    @word = Word.new(word: word_params[:word],
                     part_of_speech: word_params[:part_of_speech],
                     definitions_attributes: [
                       { definition: word_params[:definition] },
                     ])

    if @word.save
      redirect_to @word
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @word = Word.find(params[:id])
  end

  def update
    @word = Word.find(params[:id])

    if @word.update(word_params)
      redirect_to @word
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @word = Word.find(params[:id])
    @word.destroy

    redirect_to root_path, status: :see_other
  end

  private

  def word_params
    params.require(:word).permit(
      :word,
      :part_of_speech,
      :definition,
      definition_attributes: [:definition],
    )
  end
end
