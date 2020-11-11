require 'roda'
require 'sequel'
Sequel::Model.plugin :json_serializer

require './models'

class App < Roda
  plugin :all_verbs
  plugin :json_parser
  plugin :json, classes: [Array, Hash, Sequel::Model]
  MODELS = ObjectSpace.each_object(Class).select { |klass| klass < Sequel::Model }

  route do |r|
    response['Access-Control-Allow-Origin'] = '*'

    r.options do
      response['Access-Control-Allow-Headers'] = 'content-type,x-requested-with'
      ""
    end

    r.get do
      MODELS.each do |m|
        r.is m.implicit_table_name.to_s, Integer do |id|
          response['Content-Type'] = 'application/json'
          m[id].to_json(include: r.params['include'])
        end
      end
    end
  end
end

run App.freeze.app

# bundle exec puma -p 17888 -d api.ru
