variable "pet_list" {
  type = list(string)
  default = ["cat", "dog", "bird"]
}

variable "pet_count_list" {
  type = list(number)
  default = [2, 3, 5]
}

output "pets_in_room" {
  value = [
    for pet in var.pet_list : 
    "There is a ${pet} in the room."
  ]
}

output "pets_in_room_count" {
  value = [
    for index,value in var.pet_count_list : 
    "There are ${value} ${var.pet_list[index]} in the room."
  ]
}
