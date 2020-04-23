class LiveLogSchema < GraphQL::Schema
  # mutation(Types::MutationType)
  query(Types::QueryType)

  context_class CustomContext

  max_complexity 200
  max_depth 16
  default_max_page_size 20

  # region Plugins

  # Opt in to the new runtime (default in future graphql-ruby versions)
  use GraphQL::Execution::Interpreter
  use GraphQL::Analysis::AST
  use GraphQL::Execution::Errors

  use GraphQL::Pagination::Connections

  use BatchLoader::GraphQL

  # endregion

  # region Error handlers

  rescue_from ActiveRecord::RecordNotFound do |_err, _obj, _args, _ctx, field|
    raise GraphQL::ExecutionError, "#{field.type.unwrap.graphql_name} not found"
  end

  # endregion
end
