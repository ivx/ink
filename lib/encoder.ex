defimpl Poison.Encoder, for: PID do
  def encode(pid, options) do
    Poison.Encoder.BitString.encode(inspect(pid), options)
  end
end

defimpl Poison.Encoder, for: Port do
  def encode(port, options) do
    Poison.Encoder.BitString.encode(inspect(port), options)
  end
end

defimpl Poison.Encoder, for: Reference do
  def encode(ref, options) do
    Poison.Encoder.BitString.encode(inspect(ref), options)
  end
end

defimpl Poison.Encoder, for: Tuple do
  def encode(tuple, options) do
    Poison.Encoder.BitString.encode(inspect(tuple), options)
  end
end

defimpl Poison.Encoder, for: Function do
  def encode(function, options) do
    Poison.Encoder.BitString.encode(inspect(function), options)
  end
end
