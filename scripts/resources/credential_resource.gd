class_name CredentialResource
extends Resource

@export var username: String
@export var password: String
@export var source_machine: String # hostname it was found on
@export var source_path: String # filepath it was found at
@export var is_discovered: bool = false # only usable once player has found it
