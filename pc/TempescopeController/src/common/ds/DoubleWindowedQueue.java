package common.ds;

import java.util.*;

import common.ds.Tuple;

/*
 * DoubleWindowedQueue.java - generic data structure for holding a list of items so that any items with associated key older than the latest key-window is purged
 * 
 * Released as part of the Tempescope project - http://kenkawakenkenke.github.io/tempescope/
 * Copyright (c) 2013 Ken Kawamoto.  All right reserved.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

/**
 * DoubleWindowedQueue- holds only items with keys earlier than key(latest) - window
 * @author kenny
 *
 * @param <T>
 */
public class DoubleWindowedQueue<T> implements Iterable<Tuple<Double,T>>{
	public final double window;
	
	protected LinkedList<Tuple<Double,T>> queue=new LinkedList<Tuple<Double,T>>();
	
	private Double lastDouble=null;
	public Double lastDouble(){return lastDouble;}

	public DoubleWindowedQueue(double window){
		this.window=window;
	}
	
	public void clear(){
		queue=new LinkedList<Tuple<Double,T>>();
		lastDouble=null;
	}

	/**
	 * t *must* be greater or equal to lastDouble()
	 * @param t
	 * @param obj
	 */
	public int add(Double t,T obj){
		lastDouble=t;
		int numDeleted=purge(t);
		queue.add(new Tuple<Double,T>(t,obj));
		return numDeleted;
	}
	public Set<T> addAndReturnPurged(Double t,T obj){
		lastDouble=t;
		Set<T> purged=purgeAndReturnPurged(t);
		queue.add(new Tuple<Double,T>(t,obj));
		return purged;
	}
	public int purge(Double now){
		int numDeleted=0;
		Double deleteFrom=new Double(now-window);
		while(queue.size()>0 && queue.peek().fst<deleteFrom){
			queue.poll();
			numDeleted++;
		}
		return numDeleted;
	}
	public Set<T> purgeAndReturnPurged(Double now){
		HashSet<T> purged=new HashSet<T>();
		Double deleteFrom=new Double(now-window);
		while(queue.size()>0 && queue.peek().fst<deleteFrom){
			T obj=queue.poll().snd;
			purged.add(obj);
		}
		return purged;
	}
	
	public Tuple<Double,T>[] toArray(){
		Tuple<Double,T> array[]=new Tuple[size()];
		int idx=0;
		for(Tuple<Double,T> obj:this)
			array[idx++]=obj;
		return array;
	}

	public Tuple<Double,T> lastAdded(){
		return get(size()-1);
	}

	public int size(){
		return queue.size();
	}

	public Tuple<Double,T> get(int i){return queue.get(i);}

	public Iterator<Tuple<Double,T>> iterator() {
		return queue.iterator();
	}
}
