Deckhand.configure do

  model_label :pretty_name, :name, :tag

  model Foo do
    search_on :short_id, :exact
    search_on :name, :contains
    search_on :email, :contains

    show :email, :created_at
    show :bars
    show :nose, :hairy => false, :large => true
    show(:virtual_field) { ok }
    label { "#{name} <#{email}>" }
  end

  model Bar do
  end

  model Baz do
    search_on :recipient_email, :contains
    search_on :recipient_first_name, :contains
    search_on :recipient_last_name, :contains

    show :giver, :recipient, :subscription, :coupon
  end

end