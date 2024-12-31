variable "pet_count_map" {
  type = map(number)
  default = {
    "dog" = 1
    "cat" = 2
    "bird" = 3
  }
}

resource "local_file" "pet_count" {
  for_each = var.pet_count_map
  
  filename = each.key == "cat" ? "pet_cat.txt" : "pet_${each.key}.txt"
  content  = each.key == "cat" ? "${each.value} cats are in the room" : "${each.value} ${each.key}s are in the room"
}