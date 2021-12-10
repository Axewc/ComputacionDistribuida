defmodule Consensus do

  def create_consensus(n) do
    #Crear n hilos pero cada uno de esos hilos va
    #a escoger un número completamente al azar.
    #El deber del estudiante es completar la función loop
    #para que al final de un número de ejecuciones de esta,
    #todos los hilos tengan el mismo número, el cual va a ser enviado vía un
    #mensaje al hilo principal.
    Enum.map(1..n, fn _ ->
      spawn(fn -> loop(:start, 0, :rand.uniform(10), %{}, false) end)
    end)
    # Se añadió a loop dos parámetros;
    # %{} representa un map de vecinos, el cual sólo estará disponible
    #para los procesos que no fallen.
    # Un booleano que indicará si el proceso se ha decidido por un valor.
  end

  defp loop(state, value, miss_prob, vecinos, decision) do
    #inicia código inamovible.
    if(state == :fail) do
      loop(state, value, miss_prob, vecinos, decision)
    end
    # Termina código inamovible.

    receive do
      {:get_value, caller} ->
	send(caller, value) #No modificar.
    after
      1000 ->
          :ok
    end

    # Este if se encargará del consenso, un proceso sólo puede acceder
    #si ya tiene su map de vecinos y si no se ha decidido.
    if vecinos != %{} && !decision do
        Enum.each(vecinos, fn x -> send(x, {:my_value, value}) end)
        reccon(state, value, miss_prob, vecinos)
    end

    case state do
      :start ->
	chosen = :rand.uniform(10000)
	if(rem(chosen, miss_prob) == 0) do
	  loop(:fail, chosen, miss_prob, vecinos, decision)
	else
	  loop(:active, chosen, miss_prob, vecinos, decision)
    end
      :fail -> loop(:fail, value, miss_prob, vecinos, decision)
      :active ->
          #Un proceso sólo puede acceder a este if si es su primera vez.
          if vecinos == %{} do
          receive do
              {:vecinos, g} ->
                  loop(state, value, miss_prob,g, decision)
              end
          else
              loop(state, value, miss_prob, vecinos, decision)
          end
    end

  end

  # Función privada que se encargará del consenso.
  #Un proceso recibirá las propuestas de todos los vecinos y decidirá
  #el mayor valor recibido.
  defp reccon(state, value, miss_prob, vecinos) do
         receive do
            {:my_value, v} ->
                reccon(state, max(value, v), miss_prob, vecinos)
          after
             500 ->
              loop(state, value, miss_prob, vecinos, true)
          end
    end

  def consensus(processes) do
    g = grafo(processes)
    Enum.each(processes, fn p -> send(p, {:vecinos, g[p]}) end)
    IO.puts("Un momento, los procesos se están poniendo de acuerdo...")
    Process.sleep(10000)
    #Aquí va su código, deben de regresar el valor unánime decidido
    #por todos los procesos.
    Enum.each(processes, fn p -> send(p, {:get_value, self()}) end)
    receive do
        value ->
             IO.puts("Valor acordado: ")
             IO.puts(value)
             value
    after
        300 ->
        :ok
    end
  end


# Función que ocupamos para verificar el valor de cada proceso activo.
#  defp rec(valores) do
#      IO.puts("a")
#  receive do
#      value ->
#          IO.puts("e")
#          valores = valores ++ [value]
#          rec(valores)
#  after 300 -> valores
#    end
#  end

  # Para la solución, utilizamos el código para crear gráficas de la práctica 2
  #con la diferencia de que éste siempre generará gráficas completas.
  defp grafo(processes) do
    create_graph(processes, %{}, Enum.count(processes))
  end

  defp create_graph([], graph, _) do
    graph
  end

  defp create_graph([pid | l], graph, n) do
    g = create_graph(l, Map.put(graph, pid, MapSet.new()), n)
    e = div(n*(n-1), 2)
    create_edges(g, e)
  end

  defp create_edges(graph, 0) do
    graph
  end

  defp create_edges(graph, n) do
    nodes = Map.keys(graph)
    create_edges(add_edge(graph, Enum.random(nodes), Enum.random(nodes)), n-1)
  end

  defp add_edge(graph, u, v) do
    cond do
      u == nil or v == nil -> graph
      u == v -> graph
      true -> u_neighs = Map.get(graph, u)
  	  new_u_neighs = MapSet.put(u_neighs, v)
  	  graph = Map.put(graph, u, new_u_neighs)
  	  v_neighs = Map.get(graph, v)
  	  new_v_neighs = MapSet.put(v_neighs, u)
  	  Map.put(graph, v, new_v_neighs)
    end
  end

end
