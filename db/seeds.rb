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
      definition: definition,
    }
  else
    puts "Word is " + dictionary_word["word"]
  end
end

time_elapsed = Benchmark.realtime do
  # Use upsert_all to create or update Word records
  Word.upsert_all(word_data)
  # Fetch the Word records to get their IDs
  word_lookup_data = Word.where(word: word_data.map { |word_lookup| word_lookup[:word] }).pluck(:id, :word).to_h

  # Associate definitions with words and use upsert_all for Definition records
  definition_data.each do |definition_hash|
    # Use the :word key to look up the :word_id
    definition_hash[:word_id] = word_lookup_data[definition_hash[:word]]
    # Remove the reference :word key from the hash as it's not an attribute.
    definition_hash.delete(:word)
  end
  # Use upsert_all for Definition records, ensuring uniqueness based on both word_id and definition
  Definition.upsert_all(definition_data, unique_by: [:word_id])
end

puts "Database seeding completed in #{time_elapsed} seconds."
