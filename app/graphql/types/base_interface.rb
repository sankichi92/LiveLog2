module Types
  module BaseInterface
    include GraphQL::Schema::Interface

    field_class Types::BaseField
    connection_type_class Types::BaseConnection
    edge_type_class Types::BaseEdge
  end
end