require 'trinket/definitions'

def trinket(file)
  Trinket::Database.connect(file)
end

def badge(name, &block)
  if Trinket::Database::DB.uri == "sqlite:/:memory:"
    warn("WARNING: using an in memory database, you probably want to connect to a real database before defining badges")
  end

  Trinket::Definitions.module_eval do
    badge name, &block
  end
end
