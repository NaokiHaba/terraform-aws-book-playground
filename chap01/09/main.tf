variable "pet_types" {
    type = set(string)
    default = ["dog", "cat", "bird"]
}

output "unique_pet_types" {
    value = [for pet in var.pet_types : "${pet} is a pet"]
}