defmodule Longwingex.Augment.Vision do
  def copy_bboxes(img_expect_output_key_batch, box_percent, max_boxes, probability) do
    {image_set, label_set, random_key} = img_expect_output_key_batch
    probability = probability - 0.000001
    {probability_augment, new_random_key} = Nx.Random.uniform(random_key)

    {aug_image_set, aug_random_key} =
      cond do
        probability_augment < Nx.tensor(probability) ->
          Longwingex.Augment.Vision.CopyBBoxes.copy_bboxes(
            image_set, box_percent, max_boxes, new_random_key)
        true ->
          {image_set, new_random_key}
      end
    {aug_image_set, label_set, aug_random_key}
  end

  def crop(img_expect_output_key_batch, padding, probability) do
     {image_set, label_set, random_key} = img_expect_output_key_batch
    useful_probability = probability - 0.000001
    {probability_augment, new_random_key} = Nx.Random.uniform(random_key)

    {aug_image_set, aug_random_key} =
      cond do
        probability_augment < Nx.tensor(useful_probability) ->
          Longwingex.Augment.Vision.Crop.crop(
            image_set, padding, new_random_key)
        true ->
          {image_set, new_random_key}
      end
    {aug_image_set, label_set, aug_random_key}
  end

  def horizontal_flip(img_expect_output_key_batch, axis, probability) do
    {image_set, label_set, random_key} = img_expect_output_key_batch
    useful_probability = probability - 0.000001
    {probability_augment, new_random_key} = Nx.Random.uniform(random_key)

    {aug_image_set, aug_random_key} =
      cond do
        probability_augment < Nx.tensor(useful_probability) ->
          flipped_set = Nx.reverse(image_set, axes: [axis])
          {flipped_set, new_random_key}
        true ->
          {image_set, new_random_key}
      end
    {aug_image_set, label_set, aug_random_key}
  end
end
