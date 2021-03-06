# frozen_string_literal: true

create_table :developers, force: :cascade do |t|
  t.references :user, null: false, index: { unique: true }, foreign_key: true
  t.bigint :github_id, null: false
  t.string :github_username, null: false
  t.string :github_access_token

  t.timestamps

  t.index :github_id, unique: true
end
