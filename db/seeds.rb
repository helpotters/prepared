require "json"
require "rest-client"
require "benchmark"

# Get dictionary
url = "https://raw.githubusercontent.com/eddydn/DictionaryDatabase/master/EDMTDictionary.json"
post_url = "http://127.0.0.1:3000/api/words"
response = RestClient.get url
seed_dictionary = JSON.parse(response.body)

# Arrays to hold data for bulk insertions via #upsert_all (update or insert)
# Reduces SQL INSERTs/UPDATEs from 30k+ to 2.
word_data = []
definition_data = []

seed_dictionary.each do |dictionary_word|
  if dictionary_word["word"].length > 1
    word = dictionary_word["word"]
    p word
    word_type = dictionary_word["type"]
    definition = dictionary_word["description"]

    part_of_speech = "v"
    if word_type.start_with?("(n") || word_type.start_with?("(pl.") || word_type.start_with?("(interj.") || word_type.start_with?("(pron.") || word_type.end_with?("n.)")
      part_of_speech = "N"
    elsif word_type == "(adv.)" || word_type == "(adv)" || word_type.start_with?("(adv")
      part_of_speech = "Adv"
    elsif word_type.start_with?("(v")
      part_of_speech = "V"
    elsif word_type.start_with? "(a." || word_type.start_with?("(adj.)") || word_type.start_with?("(Compar.")
      part_of_speech = "Adj"
    elsif word_type.strip.start_with?("(supe")
      part_of_speech = "Adj"
    else
      puts "part of speech was #{word_type} for #{word}"
    end

    # Prepare the data into an array to allow for bulk insertion.
    word_data << {
      word: word,
      part_of_speech: part_of_speech,
    }

    # Definitions cannot be inserted via #upsert_all using nested_attributes (as far as I'm aware).
    # So, we'll make a "foreign_key" out of the word itself so we can retrieve the word_id later.
    definition_data << {
      word_id: nil, # We'll update this later
      word: word, # We'll remove this from the hash before using #upsert_all
      part_of_speech: part_of_speech,
      definition: definition,
    }
  else
    puts "Word is " + dictionary_word["word"]
  end
end

# Benchmark the SQL execution
time_elapsed = Benchmark.realtime do
  # Use upsert_all to create or update Word records
  # A word is considered an unique parent based of its part of speech (ie, Abandon (V), Abandon(Adj))
  Word.upsert_all(word_data.uniq { |word| [word[:word], word[:part_of_speech]] })

  # Fetch the Word records to get their IDs in a single query
  word_lookup_data = {}
  word_records = Word.where(
    word: word_data.map { |lookup| lookup[:word] },
    part_of_speech: word_data.map { |lookup| lookup[:part_of_speech] },
  ).pluck(:id, :word, :part_of_speech)

  word_records.each do |id, word, part_of_speech|
    word_lookup_data[word.to_sym] ||= {}
    word_lookup_data[word.to_sym][part_of_speech.to_sym] = id
  end

  # Associate definitions with words and use upsert_all for Definition records
  definition_data.each do |definition_hash|
    word_id = word_lookup_data[definition_hash[:word].to_sym][definition_hash[:part_of_speech].to_sym]
    if word_id
      # Use the :word_id obtained from the lookup
      definition_hash[:word_id] = word_id
      # Remove the reference :word and :part_of_speech keys from the hash as they're not attributes.
      definition_hash.delete(:word)
      definition_hash.delete(:part_of_speech)
    else
      # Handle the case where the word/part_of_speech combination was not found
      # You may want to log an error or take other appropriate action here.
    end
  end

  # Use upsert_all for Definition records, ensuring uniqueness based on both word_id and definition
  # #uniq is required due to duplicate definitions due to parents being merged on :part_of_speech
  Definition.upsert_all(definition_data.uniq { |defin| [defin[:word_id], defin[:definition]] })
end

puts "Database seeding completed in #{time_elapsed} seconds."
