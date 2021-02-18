class Definition < ActiveRecord::Base
#  acts_as_ferret :fields => {
#    :word        => { :boost => 10 },
#    :description  => { :boost => 2 },
#    :example     => { :boost => 1 }
#  }
  # TODO: Restore acts_as_versioned functionality
  # acts_as_versioned
  has_many :votes, :dependent => :destroy
  has_many :reactions, :dependent => :destroy
  has_many :wotds, :dependent => :destroy
  has_many :versions, class_name: 'DefinitionVersion'

  validates_presence_of :word
  validates_presence_of :description
  validates_presence_of :example

  HUMANIZED_ATTRIBUTES = {
    :word => "Woord",
    :description => "Beschrijving",
    :example => "Voorbeeld"
  }

  def initialize( *params )
  	super( *params )
  end

  def self.random_sample(count: 1, needs_positive_rating: false)
    q = self.limit(count).order('RANDOM()')
    if needs_positive_rating
      q = q.where('positivevotes > ?', 100)
    end
    # Working with a subquery so that we can order on something else than the RANDOM()
    self.where(id: q.select(:id))
  end

  def self.recent(count: 10, offset: 0)
    self.order('id DESC').limit(count).offset(offset)
  end

  def self.top(count: 10, offset: 0)
    self.order('positivevotes DESC').limit(count).offset(offset)
  end

  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def self.search(query)
   if !query.to_s.strip.empty?
      tokens = query.split.collect {|c| "%#{c.downcase}%"}
      find_by_sql(["select d.* from definitions d where #{ (["(lower(d.word) like ? or lower(d.description) like ? or lower(d.example) like ?)"] * tokens.size).join(" and ") } order by d.positivevotes desc limit 20", *(tokens * 3).sort])
   else
      []
   end
  end

  def <=>(other)
    word <=> other.word
  end

  # the user who created the initial version for this definition
  def creator
    begin
      User.find( versions.first[:updated_by] )
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  # the user who last updated the definition
  def editor
    begin
      User.find( versions.last[:updated_by] )
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

end
