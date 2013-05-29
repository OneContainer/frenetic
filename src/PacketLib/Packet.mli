(** Packet serialization library. *)

(** {9 Packet types}

    Based on {{:
    https://openflow.stanford.edu/display/ONL/POX+Wiki#POXWiki-Workingwithpacketspoxlibpacket}
    the packet library from POX}.

    You can navigate a packet's structure directly from here. But, using
    {!accs} may be more convenient.

*)

type bytes = Cstruct.t

type int8 = int

type int16 = int

type int48 = int64

type portId = int16

type dlAddr = int48

type dlTyp = int16

type dlVlan = int16 option

type dlVlanPcp = int8

type nwAddr = int32

type nwProto = int8

type nwTos = int8

type tpPort = int16

module Tcp : sig
  type t = {
    src : tpPort; 
    dst : tpPort; 
    seq : int32;
    ack : int32; 
    offset : int8; 
    flags : int16;
    window : int16; 
    chksum : int8; 
    urgent : int8;
    payload : bytes 
  }

  val parse : Cstruct.t -> t option
  val len : t -> int
  val serialize : Cstruct.t -> t -> unit

end

module Icmp : sig

  type t = {
    typ : int8;
    code : int8;
    chksum : int16;
    payload : bytes
  }

  val parse : Cstruct.t -> t option
  val len : t -> int
  val serialize : Cstruct.t -> t -> unit
end

module Ip : sig

  type tp =
    | Tcp of Tcp.t
    | Icmp of Icmp.t
    | Unparsable of bytes

  type t = {
    vhl : int8;
    tos : nwTos;
    len : int16;
    ident : int16;
    flags : int8;
    frag : int16;
    ttl : int8;
    proto : nwProto;
    chksum : int16;
    src : nwAddr;
    dst : nwAddr;
    tp : tp
  }

  val parse : Cstruct.t -> t option
  val len : t -> int
  val serialize : Cstruct.t -> t -> unit

end

module Arp : sig

  type t =
    | Query of dlAddr * nwAddr * nwAddr
    | Reply of dlAddr * nwAddr * dlAddr * nwAddr

  val parse : Cstruct.t -> t option
  val len : t -> int
  val serialize : Cstruct.t -> t -> unit

end

type nw =
  | Ip of Ip.t
  | Arp of Arp.t
  | Unparsable of bytes

type packet = {
  dlSrc : dlAddr;
  dlDst : dlAddr; 
  dlTyp : dlTyp;
  dlVlan : dlVlan;
  dlVlanPcp : dlVlanPcp;
  nw : nw
}

(** {9:accs Accessors} *)

val nwSrc : packet -> nwAddr option

val nwDst : packet -> nwAddr option

val nwTos : packet -> nwTos option

val nwProto : packet -> nwProto option

val tpSrc : packet -> tpPort option

val tpDst : packet -> tpPort option

(** {9 Mutators} *)

val setDlSrc : packet -> dlAddr -> packet

val setDlDst : packet -> dlAddr -> packet

val setDlVlan : packet -> dlVlan -> packet

val setDlVlanPcp : packet -> dlVlanPcp -> packet

val setNwSrc : packet -> nwAddr -> packet

val setNwDst : packet -> nwAddr -> packet

val setNwTos : packet -> nwTos -> packet

val setTpSrc : packet -> tpPort -> packet

val setTpDst : packet -> tpPort -> packet

(** {9 Pretty Printing} *)

val string_of_mac : int48 -> string

(* TODO(arjun): IMO it is silly to expose *all* these functions. *)
val portId_to_string : int16 -> string

val dlAddr_to_string : int48 -> string

val dlTyp_to_string : int16 -> string

val dlVlan_to_string : int16 option -> string

val dlVlanPcp_to_string : int8 -> string

val nwAddr_to_string : int32 -> string

val nwProto_to_string : int8 -> string

val nwTos_to_string : int8 -> string

val tpPort_to_string : int16 -> string

val nw_to_string : nw -> string

val packet_to_string : packet -> string

val string_of_mac : int48 -> string

val bytes_of_mac : int48 -> string

val mac_of_bytes : string -> int48

val string_of_ip : int32 -> string

(** {9:serialize Serialization} *)

val vlan_none : int
val parse : Cstruct.t -> packet option
val serialize : packet -> Cstruct.t