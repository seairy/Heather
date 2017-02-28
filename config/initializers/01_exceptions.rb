exceptions = %w(
  PermissionDenied
  AccountDoesNotExist
  IncorrectPassword
  ProhibitedAdministrator
  InvalidState
  TitleRangesMustCoverd
  SpouseRangesMustCoverd
)
exceptions.each{|e| Object.const_set(e, Class.new(StandardError))} 