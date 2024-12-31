variable "pet_count_map" {
  type = map(number)
  default = {
    "dog" = 1
    "cat" = 2
    "bird" = 3
  }
}

output "pets_in_room" {
  value = [for pet, count in var.pet_count_map : "${count} ${pet} are in the room"]
}