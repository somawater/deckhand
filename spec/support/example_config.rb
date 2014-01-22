Deckhand.configure do

  model_storage :dummy
  model_label :pretty_name, :name, :tag

  model Foo do
    search_on :name, :email
    search_on :short_id, :match => :exact
    search_scope :verified

    show :email, :created_at
    show :bars
    show :nose, :hairy => false, :large => true, :editable => true
    show(:virtual_field) { ok }
    label { "#{name} <#{email}>" }
    action :explode, :if => :explosive?
  end

  model Bar do
  end

  model Baz do
    search_on :recipient_email, :recipient_first_name, :recipient_last_name
    show :giver, :recipient, :subscription, :coupon
  end

end