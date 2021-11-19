defmodule Tree do

  def new(n) do
    create_tree(Enum.map(1..n, fn _ -> spawn(fn -> loop() end) end), %{}, 0)
  end

  defp loop() do
    receive do
       #modifiqué el receive a broadcast para que recibiera la cantidad total de procesos
      {:broadcast, tree, i, n, caller} ->
          izq = 2*i + 1  #cálculo del nodo izquierdo
          der = 2*i + 2  #cálculo del nodo derecho.

          #comprobación de existencia del nodo derecho
          if der < n do
              send(tree[der], {:broadcast, tree, der, n, caller})
          end

          #comprobación de existencia del nodo izquierdo
          if izq < n do
              send(tree[izq], {:broadcast, tree, izq, n, caller})
          else
              #si llegamos a este caso, implica que este proceso es una hoja.
              send(caller, {:ok, i, self()})
          end

      #modifiqué el receive de convergecast para no perder la referencia a la hoja
      {:convergecast, tree, i, hoja, caller} ->
          padre = trunc((i - 1)/2)

          if padre > 0 do
              send(tree[padre], {:convergecast, tree, padre, hoja, caller})
              loop()
          #Si llegamos a este else, significa que ya llegamos a la raíz
          else
              send(caller, {:ok, hoja})
              loop()
          end
    end
  end

  defp create_tree([], tree, _) do
    tree
  end

  defp create_tree([pid | l], tree, pos) do
    create_tree(l, Map.put(tree, pos, pid), (pos+1))
  end

  def broadcast(tree, n) do
      hojas = Map.new()

      #Iniciamos el algoritmo
      if n > 1 do
          send(tree[1], {:broadcast, tree, 1, n, self()})
      end

      if n > 2 do
          send(tree[2], {:broadcast, tree, 2, n, self()})
      end

        #Todas las hojas mandaron su información, procedemos a ponernas en el map
        recb(hojas)
  end

  #función auxiliar para que el proceso main guarde en un map todas las hojas que
  # le mandan mensaje
  defp recb(hojas) do
      receive do
          {:ok, i, caller} ->
              hojas = Map.put(hojas, i, caller)
              recb(hojas)
          #Hacemos esto para que, al no recibir mensajes, no se cicle
          after 200 -> hojas
       end
   end


  def convergecast(tree, n) do
    hojas = []
    num_hojas = trunc((n + 1)/2) #el número de hojas de un arbol es el piso de la división de el número de nodos más 1 entre 2
    inicio = n - num_hojas #numero donde se encuentra la primer hoja
    fin = n - 1 # número donde se encuentra la última hoja

    #iniciamos el algorito
    #Es decir, mandamos mensaje de inicio a las hojas.
    Enum.each(inicio..fin, fn x -> send(tree[x], {:convergecast, tree, x, tree[x],self()}) end)

    #los mensajes llegaron a la raíz
    recc(hojas)
  end

  #función auxiliar para que el proceso main pueda guardar e imprimir en una lista
  #de tuplas el recorrido de las hojas
  defp recc(hojas) do
      receive do
          {:ok, caller} ->
               #se añade a la lista de hojas la hoja que llegó a la raíz
               hojas = hojas ++ [{caller, :ok}]
               #volvemos a llamar a la función para agregar a las demás hojas
               recc(hojas)
      after
          #Hacemos esto para que, al no recibir mensajes, no se cicle
          200 -> hojas
      end
  end

end
