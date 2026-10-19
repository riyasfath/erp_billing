/// Shared by every viewmodel so screens check status the same way
/// regardless of which API they're talking to.
enum ViewStatus { idle, loading, success, error }