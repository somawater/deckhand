require 'deckhand/model_storage/base'

class Deckhand::ModelStorage::Mongoid < Deckhand::ModelStorage::Base

  def field_type(model, name)
    if f = field(model, name)
      type = f.options[:type]
      type ? type.to_s.underscore : nil
    elsif model.relations.include?(name.to_s)
      :relation
    end
  end

  def field(model, name)
    model.fields.detect {|f| f.first == name.to_s }.last rescue nil
  end

  def relation_class_name(model, name)
    model.constantize.relations[name.to_s].try :class_name
  end

  protected

  def query(scope, term, fields)
    scope.or(*search_criteria(term, fields)).limit(5)
  end

  private

  def search_criteria(term, fields)
    fields.map do |field, options|
      case options[:match]
      when :exact
        if field == :id
          {field => term}
        else
          {field => /^#{Regexp.escape term}$/i}
        end
      when :contains, nil
        {field => /#{Regexp.escape term}/i}
      end
    end
  end

end