class LastKnownUpdate
  def self.for id
    found = DB[:last_known_update]
    .where(updated_id: id)
    .order(:known_update)
    .last
    
    if found
      found[:known_update]
    else
      Time.new 0
      #Date.new '01.01.0001'
    end
  end
end
