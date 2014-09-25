json.call(@search, :total, :offset)
json.results do
  json.array! @search[:hits] do |hit|
    exim_trade_event = hit.deep_symbolize_keys
    json.partial! 'entry', entry: exim_trade_event
  end
end
