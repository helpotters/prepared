class Word < ApplicationRecord
  has_many :definitions

  accepts_nested_attributes_for :definitions

  validates :word, presence: true
  validates :part_of_speech, presence: true, length: { minimum: 1 }

  paginates_per 50
end
