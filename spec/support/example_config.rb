Deckhand.configure do

  model_storage :dummy
  model_label :pretty_name, :name, :tag

  model Participant do
    search_on :name, :email
    search_on :shortcode, :match => :exact
    search_scope :verified

    label { "#{name} <#{email}>" }
    show :email, :created_at
    show :groups
    show :twitter_handle, link_to: 'http://twitter.com/:value'
    show :address, :delegate => :summary, :html => true, :editable => {nested: true}
    show :text_messages, table: [:created_at, :text], lazy_load: true

    action :promote, :if => :promotable?
  end

  model Group do
    search_on :name
    show :name, :description
    show :logo, thumbnail: true, editable: true
    show :organizers, table: [:name, :email]
  end

  model Campaign do
    search_scope :active
    show :name, :duration, :status
    show :participants, table: [:name, :email, :last_active_at]
    show :random_group, type: :relation
    action :promote, :if => :promotable?
  end

  model Address do
    show :summary, :html => true
    edit :name, :street_1, :street_2, :city, :state, :postcode, :country
  end

end