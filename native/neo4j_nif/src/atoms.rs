// Elixir atoms used in the NIF
// The atoms! macro must be at module level, not inside impl
rustler::atoms! {
    ok,
    error,
    nil,
}
