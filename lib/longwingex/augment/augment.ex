defmodule Longwingex.Augment do
  def add_random_key_to_stream(x_batch_enumerable, y_batch_enumerable,
    dataset_size, batch_size, random_key) do

    random_enumerable = random_key_stream(dataset_size, batch_size, random_key)
    Stream.zip([x_batch_enumerable, y_batch_enumerable, random_enumerable])
  end

  def remove_random_key_from_stream(batch_with_random) do
    {x,y,_random_key} = batch_with_random
    {x,y}
  end

  defp random_key_stream(dataset_size, batch_size, random_key) do
    nbr_rows_of_random_keys = div(dataset_size, batch_size)
    Enum.reduce(1..nbr_rows_of_random_keys,
      [random_key],
      fn(_, random_key_list) ->
        [random_key| _rest] = random_key_list
        {_random_nbr, new_random_key} = Nx.Random.uniform(random_key)
        [new_random_key | random_key_list]
    end)
    |> Stream.cycle()
  end
end
