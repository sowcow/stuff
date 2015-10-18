class LastKnownUpdate
  def self.for id
    DB[:last_known_update]
    .where(upated_id: id)
    .order(:known_update)
    .last[:known_update]
  end
end
