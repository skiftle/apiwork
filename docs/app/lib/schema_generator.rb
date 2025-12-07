# frozen_string_literal: true

class SchemaGenerator
  def self.run
    new.run
  end

  def run
    namespaces.each { |ns| generate(ns) }
  end

  private

  def namespaces
    Dir[Rails.root.join("app/models/*/")].map { |d| File.basename(d) }
  end

  def generate(namespace)
    tables = tables_for(namespace)
    return if tables.empty?

    dir = Rails.root.join("public/#{namespace.dasherize}")
    FileUtils.mkdir_p(dir)
    File.write(dir.join("schema.md"), build_markdown(tables))
  end

  def tables_for(namespace)
    prefix = "#{namespace}_"
    ActiveRecord::Base.connection.tables.select { |t| t.start_with?(prefix) }.sort
  end

  def build_markdown(tables)
    lines = ["<!-- Auto-generated. Do not edit. -->", ""]
    tables.each { |t| lines.concat(table_section(t)) }
    lines.join("\n")
  end

  def table_section(table)
    cols = ActiveRecord::Base.connection.columns(table)
    fks = foreign_keys_for(table)

    lines = ["## #{table}", "", "| Column | Type | Constraints |", "|--------|------|-------------|"]
    cols.each do |col|
      constraints = build_constraints(col, fks)
      lines << "| #{col.name} | #{col.type} | #{constraints} |"
    end
    lines << ""
    lines
  end

  def build_constraints(col, fks)
    parts = []
    parts << "not null" unless col.null
    parts << "primary key" if col.name == "id"
    parts << "default: #{col.default}" if col.default.present?
    parts << "fk → #{fks[col.name]}" if fks[col.name]
    parts.join(", ")
  end

  def foreign_keys_for(table)
    ActiveRecord::Base.connection.foreign_keys(table).to_h { |fk| [fk.column, fk.to_table] }
  end
end
