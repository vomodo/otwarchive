# Disable pt-online-schema-change for self-hosted single-server deploy.
# AO3 gốc dùng departure cho zero-downtime migration trên cluster lớn.
# Với Mac Mini single server, standard ALTER TABLE là đủ.
module Departure
  module Migration
    def uses_departure!
      # no-op: percona toolkit không cần thiết trên single server
    end
  end
end
