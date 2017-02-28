# -*- encoding : utf-8 -*-
module Rangeable extend ActiveSupport::Concern
  included do
    scope :ranged, ->(started_at, ended_at) { where('(started_at <= ? AND ended_at >= ?) OR (started_at <= ? AND ended_at >= ?) OR (started_at > ? AND ended_at < ?)', started_at, started_at, ended_at, ended_at, started_at, ended_at) }
  end
end